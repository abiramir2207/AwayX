<cfcomponent output="false" alias="mvc.Models.Billback.vos.BBProdRate">
	<!---
	     BBProdRate :  item level detail of a billback
	--->
	<cfproperty name="isSelected" type="boolean" default="1"/>
	<cfproperty name="itemGuid" type="string" default=""/>
	<cfproperty name="itemNumber" type="string" default=""/>
	<cfproperty name="description" type="string" default=""/>
	<cfproperty name="netWeight" type="numeric" default="0"/>
	<cfproperty name="uom" type="Uom" default=""/>
	<cfproperty name="progRate" type="numeric" default="0"/>
	<cfproperty name="rate" type="numeric" default="0"/>
	<cfproperty name="volume" type="numeric" default="0"/>
	<cfproperty name="amount" type="numeric" default="0"/>
	<cfproperty name="discountType" type="numeric" default="0"/>
	<cfproperty name="bNotOnProgram" type="boolean" default="0"/>

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.isSelected = 0;
		this.itemGuid = "";
		this.itemNumber = "";
		this.description = "";
		this.netWeight = 0;
		this.uom = "";
		this.progRate = 0;
		this.rate = 0;
		this.volume = 0;
		this.amount = 0;
		this.discountType = 0;
		this.bNotOnProgram = 0;
	</cfscript>
	
	<cffunction name="init" output="false" returntype="Item">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>