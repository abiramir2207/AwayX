<cfcomponent hint="Activity Template">

	<cfset this.id 								= 0 />
	<cfset this.name 							= "" />
	<cfset this.notes 							= "" />
	<cfset this.createdBy 						= "" />
	<cfset this.updatedBy						= "" />
	<cfset this.question.freeForm.type			= 1 />
	<cfset this.question.freeForm.questions		= ArrayNew(1) />
	<cfset this.question.option.type			= 2 />
	<cfset this.question.option.options			= ArrayNew(1) />
	<cfset this.question.quantitative.type		= 3 />
	<cfset this.question.quantitative.questions	= ArrayNew(1) />


	<cffunction name="init" output="false">
		
		<cfreturn this />
		
	</cffunction>
	
	
	<!--- id setter--->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="numeric" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter--->
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- name setter--->
	<cffunction name="setName" access="public" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfset this.name = arguments.name />
	</cffunction>
	<!--- name getter--->
	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn this.name />
	</cffunction>
	
	<!--- notes setter--->
	<cffunction name="setNotes" access="public" output="false">
		<cfargument name="notes" type="string" required="true" />
		<cfset this.notes = arguments.notes />
	</cffunction>
	<!--- notes getter--->
	<cffunction name="getNotes" access="public" returntype="string" output="false">
		<cfreturn this.notes />
	</cffunction>
	
	<!--- createdBy setter--->
	<cffunction name="setCreatedBy" access="public" output="false">
		<cfargument name="createdBy" type="string" required="true" />
		<cfset this.createdBy = arguments.createdBy />
	</cffunction>
	<!--- createdBy getter--->
	<cffunction name="getCreatedBy" access="public" returntype="string" output="false">
		<cfreturn this.createdBy />
	</cffunction>
	
	<!--- updatedBy setter--->
	<cffunction name="setUpdatedBy" access="public" output="false">
		<cfargument name="updatedBy" type="string" required="true" />
		<cfset this.updatedBy = arguments.updatedBy />
	</cffunction>
	<!--- updatedBy getter--->
	<cffunction name="getUpdatedBy" access="public" returntype="string" output="false">
		<cfreturn this.updatedBy />
	</cffunction>
	
	<!---free form type setter--->
	<cffunction name="setFreeFormType" access="public" output="false">
		<cfargument name="type" type="string" required="true" />
		<cfset this.question.freeForm.type = arguments.type />
	</cffunction>
	<!---free form type getter--->
	<cffunction name="getFreeFormType" access="public" returntype="string" output="false">
		<cfreturn this.question.freeForm.type />
	</cffunction>
	
	<!--- free form questions setter--->
	<cffunction name="setFreeFormQuestions" access="public" output="false">
		<cfargument name="freeFormQuestions" type="string" required="true" default="" />
		<cfset ArrayAppend(this.question.freeForm.questions, arguments.freeFormQuestions) />
	</cffunction>
	<!--- free form questions getter--->
	<cffunction name="getFreeFormQuestions" access="public" returntype="array" output="false">
		<cfreturn this.question.freeForm.questions />
	</cffunction>
	
	<!--- option type setter--->
	<cffunction name="setOptionType" access="public" output="false">
		<cfargument name="optionType" type="string" required="true" />
		<cfset this.question.option.type = arguments.optionType />
	</cffunction>
	<!--- option type getter--->
	<cffunction name="getOptionType" access="public" returntype="string" output="false">
		<cfreturn this.question.option.type />
	</cffunction>
	
	<!--- options setter--->
	<cffunction name="setOptions" access="public" output="false">
		<cfargument name="opitons" type="struct" required="true" default="" />
		<cfset ArrayAppend(this.question.option.options, arguments.opitons) />
	</cffunction>
	<!--- options getter--->
	<cffunction name="getOptions" access="public" returntype="array" output="false">
		<cfreturn this.question.option.options />
	</cffunction>
	
	<!--- quantitative type setter--->
	<cffunction name="setQuantitativeType" access="public" output="false">
		<cfargument name="quantitativeType" type="string" required="true" />
		<cfset this.question.quantitative.type = arguments.quantitativeType />
	</cffunction>
	<!--- quantitative type getter--->
	<cffunction name="getQuantitativeType" access="public" returntype="string" output="false">
		<cfreturn this.question.quantitative.type />
	</cffunction>
	
	<!--- quantitative questions setter--->
	<cffunction name="setQuantitativeQuestions" access="public" output="false">
		<cfargument name="quantitativeQuestions" type="struct" required="true" />
		<cfset ArrayAppend(this.question.quantitative.questions, arguments.quantitativeQuestions) />
	</cffunction>
	<!--- getter--->
	<cffunction name="getQuantitativeQuestions" access="public" returntype="array" output="false">
		<cfreturn this.question.quantitative.questions />
	</cffunction>
	
</cfcomponent>
