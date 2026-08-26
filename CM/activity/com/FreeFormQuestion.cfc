
<cfcomponent hint="Free Form Question">

	<cfset this.question = "" />
	
	<cffunction name="setQuestion">
	
		<cfargument name="question" type="string" required="true" default="" />	
		<cfset this.question = arguments.question />
		
	</cffunction>
	
	<cffunction name="getQuestion" output="false">
		<cfreturn this.question />
	</cffunction>
	

</cfcomponent>