<!-----------------------------------------------------------------------------

FILE NAME:		BBClosingDetail.cfc
DESCRIPTION:	Billback Closing method Detail Declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	23-May-2011	Created

------------------------------------------------------------------------------>

<cfcomponent output="false" displayname="BBClosingDetail" alias="mvc.Models.Billback.vos.BBClosingDetail">

	<cfproperty name="bbHeader" 		type="mvc.Models.Billback.vos.BBHeader"			hint = "BillbackHeader object" />
	<cfproperty name="closingMethod" 	type="mvc.Models.Billback.vos.ClosingMethod"	hint = "Closing Method Description Payment/Deduction etc." />
 	<cfproperty name="amount" 			type="numeric"									hint = "" />
 	<cfproperty name="deduction" 		type="mvc.Models.Deduction.vos.Deduction"		hint="ID,Number,Amount,Payee"/>
	<cfproperty name="documentNumber1" 	type="string"									hint="SAP Document numer 1" />
	<cfproperty name="documentNumber2" 	type="string"									hint="SAP Document numer 2" />

	<cfscript>
		//this.bbHeader 			= CreateObject("component","mvc.Models.Billback.vos.BBHeader");
		//this.closingMethod 		= "";
		this.amount 				= 0;
		this.deduction 				= CreateObject("component","mvc.Models.Deduction.vos.Deduction");
		this.documentNumber1 		= "";
		this.documentNumber2		= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BBClosingDetail">
		<cfreturn this>
	</cffunction>

</cfcomponent>