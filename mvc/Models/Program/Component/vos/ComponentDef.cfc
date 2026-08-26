<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.ComponentDef">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="componentId" type="numeric" default="0">
	<cfproperty name="name" type="string" default="">
	<cfproperty name="type" type="numeric" default="0">
	<cfproperty name="fixedType" type="numeric" default="0">
	<cfproperty name="uom" type="array" default="">
	<cfproperty name="paidTo" type="array" default="">
	<cfproperty name="paymentCycle" type="array" default="">
	<cfproperty name="claimMechanic" type="array" default="">
	<cfproperty name="glAccount" type="array" default="">
	<cfproperty name="bGreatestValue" type="boolean" default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.componentId = 0;
		this.name = "";
		this.type = 0;
		this.fixedType = 0;
		this.uom = "";
		this.paidTo = "";
		this.paymentCycle = "";
		this.claimMechanic = "";
		this.glAccount = "";
		this.bGreatestValue = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="ComponentDef">
		<cfreturn this>
	</cffunction>

</cfcomponent>