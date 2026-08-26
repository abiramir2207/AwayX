<cfcomponent>
	<!------ *************************************************************************************
	returns sVal1 if it is not empty
	else return sVal2
	************************************************************************************* ----->
	<cffunction name="getNonEmptyValue" output="false">
		<cfargument name="sVal1" required="true" default="" type="string" />
		<cfargument name="sVal2" required="true" default="" type="string" />

		<cfif len(Arguments.sVal1)>
			<cfreturn Arguments.sVal1 />
		<cfelse>
			<cfreturn Arguments.sVal2 />
		</cfif>
		<!------ <cfreturn (iif(len(Arguments.sVal1),  "Arguments.sVal1",  "Arguments.sVal2"))> ----->
		
	</cffunction>
	
	<!------ *************************************************************************************
	
	************************************************************************************* ----->
	<cffunction name="variableExist" output="false">
		<cfargument name="sVarName" required="true" default="" type="string" />
		<cfargument name="sDefaultValue" required="false" default="" type="string" />
		
		<cfset returnValue = false>
		<cfif isDefined(arguments.sVarName)>
			<cfif Evaluate("#arguments.sVarName#") NEQ arguments.sDefaultValue>
				<cfset returnValue = true>
			</cfif>
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<!------ *************************************************************************************
	Value List of nulls result in ",,,,aaa,,sss"
	************************************************************************************* ----->
	<cffunction name="replaceMultipleChars" output="false">
		<cfargument name="sValue" required="true" default="" type="string" />
		<cfargument name="sChar" required="true" default="" type="string" />
		
		<cfset returnValue = arguments.sValue>
		<cfset returnValue = ReReplaceNoCase(returnValue, "#arguments.sChar#+", "#arguments.sChar#", "all")>
		<cfset returnValue = ReReplaceNoCase(returnValue, "^#arguments.sChar#", "", "all")>
		<cfset returnValue = ReReplaceNoCase(returnValue, "#arguments.sChar#$", "", "all")>
		
		<cfreturn returnValue />
		
	</cffunction>
	
</cfcomponent>