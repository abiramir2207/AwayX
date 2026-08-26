<cfcomponent output="false" displayname="BBDeductionFilterParms" alias="mvc.Models.Billback.vos.BBDeductionFilterParms">
	
	<cfproperty name="iBillbackId" 			type="numeric" 	hint = "" />
	<cfproperty name="bAmount" 				type="boolean"	hint = "" />	
	<cfproperty name="bDistributor"			type="boolean" />
	<cfproperty name="bBalance" 			type="boolean" 	hint = "" />
	<cfproperty name="sKeyword" 			type="string" 	hint = "ship to, bill to, deduction check number" />
	<cfproperty name="nBalance" 			type="numeric" 	hint = "" />
	<cfproperty name="strDistributorId" 	type="string" 	hint = "BSA Internal Distributor ID" />
	
	<cfscript>
		this.iBillbackId 		= 0;												
		this.bAmount 			= false;
		this.bDistributor 		= false;
		this.bBalance			= false;
		this.sKeyword 			= "";
		this.nBalance			= 0;
		this.strDistributorId	= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BBDeductionFilterParms">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>