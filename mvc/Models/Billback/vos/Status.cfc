<cfcomponent output="false" alias="mvc.Models.Billback.vos.Status">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="id" type="numeric" default="0">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="abbreviation" type="string" default="">
	<cfproperty name="subStatus" type="numeric" default="0">
	<cfproperty name="subStatusDescription" type="string" default="">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.id = 0;
		this.description = "";
		this.abbreviation = "";
		this.subStatus = 0;
		this.subStatusDescription = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Status">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>