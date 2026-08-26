<cfcomponent displayname="mvc.Models.Admin.Redi.vos.RediSettings" >
	
	<cfproperty name="sourceCode" type="string" /><!---  --->
	<cfproperty name="sourceType" type="numeric" default="0"/><!---  --->
	<cfproperty name="sourceTypeDesc" type="String" default="" />
	<cfproperty name="claimSourceXREFID" type="numeric" default="0" />
	<cfproperty name="tradePartId" type="String" default=""/><!---  --->
	<cfproperty name="bEnabled" type="boolean" default="0"/><!--- --->
	<cfproperty name="bAliasItem" type="boolean" default="0"/><!--- --->
	<cfproperty name="bAliasDistributor" type="boolean" default="0"/><!--- --->
	<cfproperty name="bAliasOriginalBuyer" type="boolean" default="0"/><!--- --->
	<cfproperty name="sFOBPricInd" type="String" default=""/><!--- --->
	<cfproperty name="iInvoicePrice" type="numeric" default="0"/><!--- --->
	<cfproperty name="iInvoiceNumber" type="String" default=""/>
	<cfproperty name="aEmailRecipients" type="array" default=""/>
	<cfproperty name="sModifiedUser" type="String" default=""/>
	<cfproperty name="dModifiedDate" type="date" default=""/>
	

	<cfscript>
		//Initialize the CFC with the default properties values.;
		
		this.sourceCode = '';
		this.sourceType = 0;//
		this.sourceTypeDesc = '';//DOT, Sysco, Honor
		this.claimSourceXREFID = 0;
		this.tradePartId = '';
		this.bEnabled = 0;
		this.bAliasItem = 0;
		this.bAliasDistributor = 0;
		this.bAliasOriginalBuyer = 0;
		this.sFOBPricInd = '';
		this.iInvoicePrice = 0; //1 = raw file; 2= Forge Generated
		this.iInvoiceNumber = 0;//1 = raw file; 2= Forge Generated
		this.aEmailRecipients = ArrayNew(1);
		this.sModifiedUser = '';
		this.dModifiedDate = Now();
		
	</cfscript>
	
	<cffunction name="init" output="false" returntype="mvc.Models.Admin.Redi.vos.RediSettings">
		<cfreturn this>
	</cffunction>

</cfcomponent>