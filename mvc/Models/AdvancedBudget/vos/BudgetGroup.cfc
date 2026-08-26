<cfcomponent alias="mvc.Models.AdvancedBudget.BudgetGroup" displayname="BudgetGroup">

	<cfproperty name="id" 				type="numeric" 	hint = "" default="" />
	<cfproperty name="number" 			type="string" 	hint = "" default="" />
	<cfproperty name="desc" 			type="string" 	hint = "" default="" />
	<cfproperty name="active" 			type="boolean" 	hint = "" default="" />
	<cfproperty name="lastUpdatedDate" 	type="date" 	hint = "" default="" />
	<cfproperty name="lastUpdatedBy" 	type="string" 	hint = "" default="" />


	<cfscript>														
		this.id 			= 0;
		this.number 		= "";
		this.desc 			= "";
		this.active 		= 1;
		this.lastUpdatedDate = "";
		this.lastUpdatedBy 	= "";	 
	</cfscript>
	
</cfcomponent>