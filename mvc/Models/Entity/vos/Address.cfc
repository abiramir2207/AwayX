<!-----------------------------------------------------------------------------

FILE NAME:		Address.cfc
DESCRIPTION:	Address type declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	27-Apr-2011	Created
							
------------------------------------------------------------------------------> 
<cfcomponent output="false" alias="mvc.Models.Entity.vos.Address">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="addressLine1" type="string" default="">
	<cfproperty name="addressLine2" type="string" default="">
	<cfproperty name="city" 				type="string" default="">
	<cfproperty name="state" 				type="string" default="">
	<cfproperty name="zipCode" 			type="string" default="">
					
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.addressLine1= "";
		this.addressLine2= "";
		this.city= "";
		this.state= "";
		this.zipCode= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Address">
		<cfreturn this>
	</cffunction>

</cfcomponent>