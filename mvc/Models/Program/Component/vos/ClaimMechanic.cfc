<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.ClaimMechanic">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="claimMechanicId" type="numeric" default="0">
	<cfproperty name="description" 	type="string" 	default="">
	<cfproperty name="payeeTypeId" 	type="numeric" 	default="0">
	<cfproperty name="restrictBB" 	type="boolean" 	default="false">
	<cfproperty name="bAutoPay" 	type="boolean" 	default="false">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.claimMechanicId = 0;
		this.description = "";
		this.payeeTypeId = 0;
		this.restrictBB = 0;
		this.bAutoPay = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="ClaimMechanic">
		<cfreturn this>
	</cffunction>

</cfcomponent>