<cfcomponent output="false" displayname="BBDetails" alias="mvc.Models.Admin.Alias.vos.AliasDef">
	<cfproperty name="isSelected" type="boolean">		
	<cfproperty name="entityType" type="numeric">
	<cfproperty name="sourceType" type="numeric">
	<cfproperty name="sourceTypeDesc" type="string">
	<cfproperty name="sourceID" type="string"> 
	<cfproperty name="payeeID" type="string"> 
	<cfproperty name="recordID" type="numeric"> 
	<cfproperty name="aliasID" type="string">
	<cfproperty name="aliasDesc" type="string">
	<cfproperty name="aliasAddress" type="string">
	<cfproperty name="aliasRegion" type="string">
	<cfproperty name="aliasCity" type="string">
	<cfproperty name="aliasState" type="string">
	<cfproperty name="aliasZIP" type="string">
	<cfproperty name="aliasUniproNum" type="string">
	<cfproperty name="aliasLoc" type="string">
	<cfproperty name="entityID" type="string">
	<cfproperty name="entityDesc" type="string">
	<cfproperty name="entityAddress" type="string">
	<cfproperty name="bsaId" type="string">
	<cfproperty name="isAssigned" type="boolean">
	<cfproperty name="holdInvoiceCount" type="numeric">
	<cfproperty name="sourceRecordID" type="numeric"><!--- It is boolean in db. An integer gets converted to boolean in db. --->
	<cfproperty name="Unknown" type="boolean"><!--- It is boolean in db. An integer gets converted to boolean in db. --->

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.isSelected = 0;
		this.entityType = 0;  		//distributors OR Items OR Programs
		this.sourceType = 0;		//EDI OR other entities like Vendor etc
		this.sourceTypeDesc = '';	// SYSCO EDI OR USFS EDI OR CBS 3rd Party etc
		this.sourceID = '';			//Hardcoded for EDI ID but dynamic for entities like Vendor etc
		this.payeeID = '';			//currently, this is the vendor ID 
		this.recordID = 0;			//Incremental Integer - Unique ID
		this.aliasID = '';
		this.aliasDesc = '';
		this.aliasAddress = '';
		this.aliasRegion = '';
		this.aliasCity = '';
		this.aliasState = '';
		this.aliasZIP = '';
		this.aliasUniproNum = '';
		this.aliasLoc = '';
		this.entityID = '';
		this.entityDesc = '';
		this.entityAddress = '';
		this.bsaId = '';
		this.isAssigned = 0;
		this.holdInvoiceCount = 0;
		this.sourceRecordID = 0;
		this.Unknown = 0;
	</cfscript>

	<cffunction name="init" output="false" returntype="AliasDef">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>