<cfcomponent output="false" alias="mvc.Models.Template.vos.Template">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
		 
	--->
	<cfproperty name="templateId" type="numeric" default="0">
	<cfproperty name="firstParentId" type="numeric" default="0">
	<cfproperty name="bCustomPrint" type="boolean" default="0">
	<cfproperty name="bGroupDeal" type="boolean" default="0">
	<cfproperty name="bFixedGroupDeal" type="boolean" default="0">
	<cfproperty name="bRebateGroupDeal" type="boolean" default="0">
	<cfproperty name="genericType" type="string" default="">
	<cfproperty name="createdType" type="string" default="">
	<cfproperty name="templateFiltersId" type="numeric" default="0">
	<cfproperty name="claimMechanicChanged" type="numeric" default="1">
	<cfproperty name="paymentFrequencyChanges" type="numeric" default="1">
	<cfproperty name="bCurrencyConversionFactor" type="boolean" default="0">
	<cfproperty name="bEZButtonOn" type="boolean" default="0">
	<cfproperty name="bDiscountRebateMaxRateOn" type="boolean" default="0">
	<cfproperty name="bEzButtonDefaultShowItemRates" type="boolean" default="0">
	<cfproperty name="bEzButtonEnterBeyondMaxRates" type="boolean" default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.templateId = 0;
		this.firstParentId = 0;
		this.bCustomPrint = JavaCast("boolean",false );
		this.bGroupDeal = JavaCast("boolean",false );
		this.bFixedGroupDeal = JavaCast("boolean",false );
		this.bRebateGroupDeal = JavaCast("boolean",false );
		this.genericType = '';
		this.createdType = '';
		this.templateFiltersId = 0;
		this.claimMechanicChanged = 1;
		this.paymentFrequencyChanges = 1;
		this.bCurrencyConversionFactor = 0;
		this.bEZButtonOn = 0;
		this.bDiscountRebateMaxRateOn = 0;
		this.bEzButtonDefaultShowItemRates = 0;
		this.bEzButtonEnterBeyondMaxRates = 0;

	</cfscript>

	<cffunction name="init" output="false" returntype="Program">
		<cfreturn this>
	</cffunction>

</cfcomponent>