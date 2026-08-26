<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.Uom">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="uomId" type="numeric" default="0">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="abbreviation" type="string" default="">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.uomId = 0;
		this.description = "";
		this.abbreviation = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Uom">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>