<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.Component">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services,
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="isSelected" type="boolean" default="0" />
	<cfproperty name="componentId" type="numeric" default="0" />
	<cfproperty name="name" type="string" default="" />
	<cfproperty name="type" type="numeric" default="0" />
	<cfproperty name="fixedType" type="numeric" default="0" />
	<cfproperty name="prodRate" type="array" default="" />
	<cfproperty name="uom" type="array" default="" />
	<cfproperty name="paidTo" type="PaidTo" default="" />
	<cfproperty name="paymentCycle" type="PaymentCycle" default="" />
	<cfproperty name="claimMechanic" type="mvc.Models.Program.Component.vos.ClaimMechanic" default="" />
	<cfproperty name="payee" type="Payee" default="" />
	<cfproperty name="glAccount" type="GlAccount" default="" />
	<cfproperty name="bMarketPriceTemplate" type="boolean" default="0" />
	<cfproperty name="amount" type="numeric" default="0" />
	<cfproperty name="programId" type="numeric" default="0" />
	<cfproperty name="programNumber" type="string" default="" />
	<cfproperty name="programTitle" type="string" default="" />
	<cfproperty name="compDescription" type="string" default="" />
	<cfproperty name="compRate" type="string" default="" />
	<cfproperty name="programComponentId" type="string" default="" />
	<cfproperty name="customPrint" type="mvc.Models.Program.Component.vos.CustomPrint" default="" />
	<cfproperty name="componentDef" type="mvc.Models.Program.Component.vos.ComponentDef" default="0" />


	<cfscript>
		//Initialize the CFC with the default properties values.
		this.isSelected = 0;
		this.componentId = 0;
		this.name = "";
		this.type = 0;
		this.fixedType = 0;;
		this.prodRate = "";
		this.uom = "";
		this.paidTo = "";
		this.paymentCycle = "";
		this.claimMechanic = CreateObject("component","mvc.Models.Program.Component.vos.ClaimMechanic");
		this.payee = "";
		this.glAccount = "";
		this.bMarketPriceTemplate = 0;
		this.amount = 0;
		this.programId = 0;
		this.programNumber = "";
		this.programTitle = "";
		this.compDescription = "";
		this.compRate = "";
		this.programComponentId = "";
		this.customPrint = CreateObject("component","mvc.Models.Program.Component.vos.CustomPrint");
		this.componentDef = CreateObject("component","mvc.Models.Program.Component.vos.ComponentDef");
	</cfscript>

	<cffunction name="init" output="false" returntype="Component">
		<cfreturn this>
	</cffunction>

</cfcomponent>