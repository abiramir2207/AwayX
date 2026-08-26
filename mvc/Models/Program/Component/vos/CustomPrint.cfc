<cfcomponent output="false" alias="mvc.Models.Program.Component.vos.CustomPrint">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->
	<cfproperty name="bCustomPrint" type="boolean"	default="0">
	<cfproperty name="iColors"		type="numeric"	default="0">
	<cfproperty name="sGraphics"	type="string"	default="">
	<cfproperty name="bDigital" 	type="boolean"	default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		this.bCustomPrint= 0;
		this.iColors = 0;
		this.sGraphics = "";
		this.bDigital = 0;
	</cfscript>

	<!---<cffunction name="init" output="false" returntype="CustomPrint">
		<cfreturn this>
	</cffunction>--->

</cfcomponent>