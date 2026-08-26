<cfcomponent output="false" alias="mvc.Models.Billback.vos.Type">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services,
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="id" type="numeric" default="0">
	<cfproperty name="description" type="string" default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.id = 0;
		this.description = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Type">
		<cfreturn this>
	</cffunction>

</cfcomponent>