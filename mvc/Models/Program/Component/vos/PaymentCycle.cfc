<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.PaymentCycle">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="paymentCycleId" type="numeric" default="0">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="bDefault" type="boolean" default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.paymentCycleId = 0;
		this.description = "";
		this.bDefault = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="PaymentCycle">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>