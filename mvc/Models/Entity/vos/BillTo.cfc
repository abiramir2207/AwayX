<!-----------------------------------------------------------------------------

FILE NAME:		BillTo.cfc
DESCRIPTION:	Bill To type declaration
CREATED BY:		Tim Ford
MODIFICATION HISTORY:	BY			DATE		DESCRIPTION OF CHANGE
			
						Tim Ford	03/13/2012	Created
							
------------------------------------------------------------------------------> 
<cfcomponent output="false" alias="mvc.Models.Entity.vos.BillTo">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	
	<cfproperty name="billTo" 		type="string" 							default="" hint="Bill To ID" />
	<cfproperty name="name" 		type="string" 							default="" hint="Bill To Name" />
	<cfproperty name="address" 		type="mvc.Models.Entity.vos.Address" 	hint="Address field" />
	<cfproperty name="billToId" 	type="string" 							default="" hint="Internal BSA Bill To ID" />	
	<cfproperty name="shipTo" 		type="string" 							default="" hint="Ship To ID" />
	<cfproperty name="shipToId" 	type="string" 							default="" hint="Internal BSA Ship To ID" />	
					
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.billTo= "";
		this.name= "";
		this.address= "";
		this.billToId= "";
		this.shipTo= "";
		this.shipToId= "";
	</cfscript>

	<cffunction name="init" output="false" returntype="BillTo">
		<cfreturn this>
	</cffunction>

</cfcomponent>