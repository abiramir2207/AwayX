<!-----------------------------------------------------------------------------

FILE NAME:		Deduction.cfc
DESCRIPTION:	Deduction Object Declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	23-May-2011	Created

------------------------------------------------------------------------------>

<cfcomponent output="false" displayname="Deduction" alias="mvc.Models.Deduction.vos.Deduction">

	<cfproperty name="deductionID" 		type="string" 	hint = "Deductions.Deduction_ID[uniqueidentifier]" />
	<cfproperty name="deductionNumber" 	type="string" 	hint = "Deductions.DD_DedID[varchar(100)]" />
	<cfproperty name="amount" 			type="numeric" 	hint = "Deductions.DD_Amount" />
	<cfproperty name="ddDate"			type="string" 	hint = "Deductions.DD_Date" />
	<cfproperty name="ddReference"		type="string" 	hint = "Deductions.DD_Reference" />
	<cfproperty name="ddCheckNumber"	type="string" 	hint = "Deductions.DD_Check_Number" />
	<cfproperty name="spNumber"			type="string" 	hint = "Deductions.SP_Number" />
 	<cfproperty name="brokerObj" 		type="mvc.Models.Entity.vos.Payee" 	hint="Payee Number, Name"/>
	<cfproperty name="distObj" 			type="mvc.Models.Entity.vos.Payee" 	hint="Payee Number, Name"/>
	<cfproperty name="analystObj"		type="mvc.Models.Entity.vos.User" 	hint = "UserID, Fullname" />
	<cfproperty name="lockObj"			type="mvc.Models.Entity.vos.Lock" 	hint = "UserID, Fullname" />
	<cfproperty name="amountParent" 	type="numeric" 	hint = "Parent DD_Amount" />
	<cfproperty name="ddSpNumberParent"	type="string" 	hint = "Parent DD_DedID_SP_Number" />

	<cfscript>
 		this["deductionID"] 		= "";
		this["deductionNumber"] 	= "";
		this["amount"]			= "0";
		this["ddDate"]				= "";
		this["ddReference"]		= "";
		this["ddCheckNumber"]		= "";
		this["spNumber"]			= "";
		this["brokerObj"]			= CreateObject("component","mvc.Models.Entity.vos.Payee");
		this["distObj"]			= CreateObject("component","mvc.Models.Entity.vos.Payee");
		this["analystObj"]			= CreateObject("component","mvc.Models.Entity.vos.User");
		this["lockObj"]			= CreateObject("component","mvc.Models.Entity.vos.Lock");
		this["amountParent"]		= "0";
		this["ddSpNumberParent"]	= "";

	</cfscript>

	<cffunction name="init" output="false" returntype="Deduction">
		<cfreturn this>
	</cffunction>

</cfcomponent>
