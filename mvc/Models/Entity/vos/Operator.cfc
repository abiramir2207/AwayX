<!-----------------------------------------------------------------------------

FILE NAME:		Operator.cfc
DESCRIPTION:	Operator type declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	28-Apr-2011	Created
							
------------------------------------------------------------------------------> 
<cfcomponent output="false" alias="mvc.Models.Entity.vos.Operator">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	
	<cfproperty name="ID" 	type="string" default="" hint="Operator Unit ID" />
	<cfproperty name="name" 		type="string" default="" hint="Operator Unit Name" />
	<cfproperty name="address" 	type="mvc.Models.Entity.vos.Address" hint="Address field" />	
					
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.ID= "";
		this.name= "";
		this.address= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="Operator">
		<cfreturn this>
	</cffunction>

</cfcomponent>