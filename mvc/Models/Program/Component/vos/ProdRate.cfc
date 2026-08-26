<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.ProdRate">
	<!---
		 These are properties that are exposed by this CFC object.
		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="itemGuid" type="string" default="">
	<cfproperty name="itemNumber" type="string" default="">
	<cfproperty name="description" type="string" default="">
	<cfproperty name="netWeight" type="numeric" default="0">
	<cfproperty name="uom" type="Uom" default="">
	<cfproperty name="rate" type="numeric" default="0">
	<cfproperty name="rateMP" type="numeric" default="0">
	<cfproperty name="rateMPOrig" type="numeric" default="0">
	<cfproperty name="rateConverted" type="numeric" default="0">
	<!---<cfproperty name="newRateMP" type="numeric" default="0">
	<cfproperty name="uomMP" type="Uom" default="">
	<cfproperty name="varianceMP" type="Uom" default="">
	<cfproperty name="variancePercMP" type="numeric" default="0">--->
	<cfproperty name="volume" type="numeric" default="0">
	<cfproperty name="compDescription" type="string" default="">
	<cfproperty name="bActive" type="Boolean" default="0">
	<cfproperty name="rateEz" type="numeric" default="0">
	<cfproperty name="uomEz" type="Uom" default="">
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.itemGuid = "";
		this.itemNumber = "";
		this.description = "";
		this.netWeight = 0;
		this.uom = "";
		this.rate = 0;
		this.rateMP = 0;
		this.rateMPOrig = 0;
		this.rateConverted = 0;
		//this.newRateMP = 0;
		this.volume = 0;
		this.compDescription = "";
		this.bActive = javacast("boolean",0);
		this.uomEz = "";
		this.rateEz = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="ProdRate">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>