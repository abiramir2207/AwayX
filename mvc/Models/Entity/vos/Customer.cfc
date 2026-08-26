<!-----------------------------------------------------------------------------

FILE NAME:		Customer.cfc
DESCRIPTION:	Customer type declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	28-Apr-2011	Created

------------------------------------------------------------------------------>
<cfcomponent output="false" alias="mvc.Models.Entity.vos.Customer">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services,
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->

	<cfproperty name="shipTo" 		type="string" 							default="" hint="Customer Distributor Code" />
	<cfproperty name="name" 		type="string" 							default="" hint="Customer Distributor Name" />
	<cfproperty name="address" 		type="mvc.Models.Entity.vos.Address" 	hint="Address field" />
	<cfproperty name="aliasShipTo" 	type="string" 							default="" hint="external code" />
	<cfproperty name="aliasName" 	type="string" 							default="" hint="external Name" />
	<cfproperty name="aliasAddress" type="mvc.Models.Entity.vos.Address" 	hint="external Address field" />
	<cfproperty name="aliasRecordId"type="numeric"							default="0" hint="unique id for alis data" />
	<cfproperty name="customerId" 	type="string" 							default="" hint="Internal BSA Customer ID" />

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.shipTo= "";
		this.name= "";
		this.address= createObject("component", "mvc.Models.Entity.vos.Address");
		this.aliasShipTo= "";
		this.aliasName= "";
		this.aliasAddress= createObject("component", "mvc.Models.Entity.vos.Address");
		this.aliasRecordId = 0;
		this.customerId= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Customer">
		<cfreturn this>
	</cffunction>

</cfcomponent>