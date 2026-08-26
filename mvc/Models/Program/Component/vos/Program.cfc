<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.Program">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="programId" type="numeric" default="0">
	<cfproperty name="title" type="string" default="">
	<cfproperty name="number" type="string" default="">
	<cfproperty name="startDate" type="date" default=""> 
	<cfproperty name="endDate" type="date" default="">	
	<cfproperty name="distributors" type="array" default="">
	<cfproperty name="operators" type="array" default="">
	<cfproperty name="components" type="array" default="">
	<cfproperty name="componentType" type="array" default="">
	<cfproperty name="bMarketPriceTemplate" type="boolean" default="0">
	<cfproperty name="arrPrdAttr" type="array" default="">
	<cfproperty name="arrCustomers" type="array" default="">
	<cfproperty name="conversionFactor" type="string" default="0">
	<cfproperty name="bHasConversionFactor" type="boolean" default="0">
	<cfproperty name="template" type="mvc.Models.Template.vos.Template" default="">
	<cfproperty name="bRevision" type="boolean" default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.programId = 0;
		this.title = "";
		this.number = "";

		this.startDate = "";
		this.endDate = "";
		this.distributors = "";
		this.operators = "";

		this.components = "";
		this.componentType = "";
		this.bMarketPriceTemplate = JavaCast("boolean",false );
		this.arrPrdAttr = "";
		this.arrCustomers = "";
		this.conversionFactor = 0;
		this.bHasConversionFactor = 0;
		this.template = '';
		this.bRevision = JavaCast("boolean",false );
	</cfscript>

	<cffunction name="init" output="false" returntype="Program">
		<cfreturn this>
	</cffunction>


</cfcomponent>