<cfcomponent displayname="mvc.Models.Program.Fitness.vos.FitnessDetail" >
	
	<cfproperty name="item" type="String" default=""/><!---item--->
	<cfproperty name="description" type="String" default=""/><!---description--->
	<cfproperty name="sigLabel" type="String" default=""/><!---sigLabel--->
	<cfproperty name="eligibility" type="string" default="" />
	<cfproperty name="yago" type="numeric" default="0"/><!--- yago --->
	<cfproperty name="revenue" type="numeric" default="0"/><!--- revenue --->
	<cfproperty name="cases" type="numeric" default="0"/><!--- cases --->
	<cfproperty name="lbs" type="numeric" default="0"/><!--- lbs --->
	<cfproperty name="yagoNon" type="numeric" default="0"/><!--- yagoNon --->
	<cfproperty name="revenueNon" type="numeric" default="0"/><!--- revenueNon --->
	<cfproperty name="casesNon" type="numeric" default="0"/><!--- casesNon --->
	<cfproperty name="lbsNon" type="numeric" default="0"/><!--- lbsNon --->
	<cfproperty name="qBrand" type="String" default=""/>
	<cfproperty name="prodVarA" type="String" default=""/>
	<cfproperty name="typeCodeDesc" type="String" default=""/>

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.item = '';
		this.description = '';
		this.sigLabel = '';
		this.eligibility = '';
		this.yago = 0;
		this.revenue = 0;
		this.cases = 0;
		this.lbs = 0;
		this.yagoNon = 0;
		this.revenueNon = 0;
		this.casesNon = 0;
		this.lbsNon	 = 0;
		this.qBrand = '';
		this.prodVarA = '';
		this.typeCodeDesc = '';
	</cfscript>
	
	<cffunction name="init" output="false" returntype="FitnessDetail" >
		<cfreturn this>
	</cffunction>

</cfcomponent>