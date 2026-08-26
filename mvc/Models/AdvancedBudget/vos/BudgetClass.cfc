<cfcomponent alias="mvc.Models.AdvancedBudget.BudgetClass" displayname="BudgetClass">

	<cfproperty name="id" 			type="numeric" 	hint = "" default="" />
	<cfproperty name="number" 		type="string" 	hint = "" default="" />
	<cfproperty name="desc" 		type="string" 	hint = "" default="" />
	<cfproperty name="isFiscal" 	type="boolean" 	hint = "" default="" />
	<cfproperty name="year" 		type="string" 	hint = "" default="" />
	<cfproperty name="startDate" 	type="date" 	hint = "" default="" />
	<cfproperty name="endDate" 		type="date" 	hint = "" default="" />
	<cfproperty name="active" 		type="boolean" 	hint = "" default="" />
	<cfproperty name="lastUpdatedDate" 	type="date" 	hint = "" default="" />
	<cfproperty name="lastUpdatedBy" 	type="string" 	hint = "" default="" />
	<cfproperty name="Partial_Year" 	type="boolean" 	hint = "" default="" />


	<cfscript>
		this.id 			= 0;
		this.number 		= "";
		this.desc 			= "";
		this.isFiscal 		= 1;
		this.year 			= "";
		this.startDate 		= "";
		this.endDate 		= "";
		this.active 		= 1;
		this.lastUpdatedDate = "";
		this.lastUpdatedBy 	= "";
		this.Partial_Year = 0;
	</cfscript>

</cfcomponent>