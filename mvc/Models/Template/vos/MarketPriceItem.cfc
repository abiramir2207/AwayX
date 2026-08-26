<cfcomponent output="false" alias="mvc.Models.Template.vos.MarketPriceItem">
	
	<cfproperty name="itemGuid" type="string" default="">
	<cfproperty name="itemNumber" type="string" default="">
	<cfproperty name="uom" type="Uom" default="">
	<cfproperty name="rate" type="numeric" default="0">
	
	<!---<cfscript>
		//Initialize the CFC with the default properties values.
		this.itemGuid = "";
		this.itemNumber = "";
		this.uom = 0;
		this.rate =  "";
	</cfscript>
	
	<cffunction name="init" output="false" >
		<cfreturn this>
	</cffunction>--->

</cfcomponent>