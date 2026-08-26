<cfcomponent extends="components.AjaxCFC.ajax">

	<cffunction name="getLumpSumTotalAJAXCall" output="false" access="private">
		
		<cfargument name="id" required="true" type="numeric" />
		
			<cfset var result = "" />
			
			<cfset result = CreateObject("component", "components.programs.template.TemplateManager").getLumpSumTotal(arguments.id) />
			
			<cfreturn result>
			
	</cffunction>
	
</cfcomponent>