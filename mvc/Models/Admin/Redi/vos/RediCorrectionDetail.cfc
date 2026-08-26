<cfcomponent displayname="mvc.Models.Admin.Redi.vos.RediCorrectionDetail" >
	
	<cfproperty name="rediCorrectionHeaderId" type="numeric" default=""/><!--- unique id in DB --->
	<cfproperty name="rediCorrectionDetailId" type="numeric" default=""/><!--- unique id in DB --->
	<cfproperty name="isSelected" type="Boolean" default="" />
	<cfproperty name="item" type="String" default=""/><!---Manufacturer--->
	<cfproperty name="itemDesc" type="String" default=""/><!---Manufacturer--->
	<cfproperty name="itemPackSize" type="numeric" default=""/><!---Manufacturer--->
	<cfproperty name="aliasItem" type="String" default=""/><!---Alias--->
	<cfproperty name="aliasItemDesc" type="String" default=""/><!---Alias--->
	<cfproperty name="aliasItemPackSize" type="numeric" default=""/><!---Alias--->
	<cfproperty name="aliasRecordId"type="numeric"	default="0" hint="unique id for alis data" />
	<cfproperty name="invoiceCases" type="numeric" default="0"/>
	<cfproperty name="invoicePriceCS" type="numeric" default="0"/>
	<cfproperty name="invoicePriceLB" type="numeric" default="0"/>
	<cfproperty name="errorMessage" type="String" default=""/>
	

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.rediCorrectionHeaderId = 0;
		this.rediCorrectionDetailId = 0;
		this.isSelected = 0;
		this.item = '';
		this.itemDesc = '';
		this.itemPackSize = 0;
		this.aliasItem = '';
		this.aliasItemDesc = '';
		this.aliasItemPackSize = 0;
		this.aliasRecordId = 0;
		this.invoiceCases = 0;
		this.invoicePriceCS = 0;
		this.invoicePriceLB = 0;
		this.errorMessage = '';
		
	</cfscript>
	
	<cffunction name="init" output="false" returntype="RediCorrectionDetail" >
		<cfreturn this>
	</cffunction>

</cfcomponent>