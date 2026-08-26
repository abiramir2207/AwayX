<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.Payee">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="payeeTypeId" type="numeric" default="0">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="payeeId" type="string" default="">
	<cfproperty name="address" type="string" default="">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.payeeTypeId = 0;
		this.name = "";
		this.payeeId = "";
		this.address = "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Payee">
		<cfreturn this>
	</cffunction>

</cfcomponent>